package com.example.orderservice.service;

import com.example.orderservice.model.Order;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.*;

@Service
public class OrderService {

    @Autowired
    private RestTemplate restTemplate;

    @Value("${user.service.url:http://user-service:8080}")
    private String userServiceUrl;

    @Value("${product.service.url:http://product-service:8080}")
    private String productServiceUrl;

    @Value("${notification.service.url:http://notification-service:8080}")
    private String notificationServiceUrl;

    private Map<Long, Order> orders = new HashMap<>();
    private Long nextId = 1L;

    public List<Order> getAllOrders() {
        return new ArrayList<>(orders.values());
    }

    public Order getOrderById(Long id) {
        return orders.get(id);
    }

    public Order createOrder(Order order) {
        // Validate user exists
        try {
            restTemplate.getForObject(userServiceUrl + "/api/users/" + order.getUserId(), Object.class);
        } catch (Exception e) {
            throw new RuntimeException("User not found");
        }

        // Get product and calculate total
        try {
            Map<String, Object> product = restTemplate.getForObject(
                    productServiceUrl + "/api/products/" + order.getProductId(), Map.class);
            BigDecimal price = new BigDecimal(product.get("price").toString());
            order.setTotalAmount(price.multiply(new BigDecimal(order.getQuantity())));
        } catch (Exception e) {
            throw new RuntimeException("Product not found");
        }

        // Update product stock
        try {
            restTemplate.put(productServiceUrl + "/api/products/" + order.getProductId() +
                    "/stock?quantity=" + order.getQuantity(), null);
        } catch (Exception e) {
            System.err.println("Failed to update product stock");
        }

        order.setId(nextId++);
        order.setStatus("CREATED");
        orders.put(order.getId(), order);

        // Send notification
        try {
            Map<String, Object> notification = new HashMap<>();
            notification.put("userId", order.getUserId());
            notification.put("message", "Order " + order.getId() + " has been created");
            restTemplate.postForObject(notificationServiceUrl + "/api/notifications", notification, Object.class);
        } catch (Exception e) {
            System.err.println("Failed to send notification");
        }

        return order;
    }
}
