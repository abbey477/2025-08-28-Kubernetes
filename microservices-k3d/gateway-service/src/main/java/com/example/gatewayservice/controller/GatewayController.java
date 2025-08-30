package com.example.gatewayservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api")
public class GatewayController {

    @Autowired
    private RestTemplate restTemplate;

    @Value("${user.service.url:http://user-service:8080}")
    private String userServiceUrl;

    @Value("${product.service.url:http://product-service:8080}")
    private String productServiceUrl;

    @Value("${order.service.url:http://order-service:8080}")
    private String orderServiceUrl;

    @Value("${notification.service.url:http://notification-service:8080}")
    private String notificationServiceUrl;

    @RequestMapping(value = "/users/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public ResponseEntity<Object> routeToUserService(HttpServletRequest request, @RequestBody(required = false) Object body) {
        return routeRequest(userServiceUrl, request, body);
    }

    @RequestMapping(value = "/products/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public ResponseEntity<Object> routeToProductService(HttpServletRequest request, @RequestBody(required = false) Object body) {
        return routeRequest(productServiceUrl, request, body);
    }

    @RequestMapping(value = "/orders/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public ResponseEntity<Object> routeToOrderService(HttpServletRequest request, @RequestBody(required = false) Object body) {
        return routeRequest(orderServiceUrl, request, body);
    }

    @RequestMapping(value = "/notifications/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public ResponseEntity<Object> routeToNotificationService(HttpServletRequest request, @RequestBody(required = false) Object body) {
        return routeRequest(notificationServiceUrl, request, body);
    }

    private ResponseEntity<Object> routeRequest(String serviceUrl, HttpServletRequest request, Object body) {
        String path = request.getRequestURI();
        String queryString = request.getQueryString();
        String fullUrl = serviceUrl + path + (queryString != null ? "?" + queryString : "");

        try {
            switch (request.getMethod()) {
                case "GET":
                    return ResponseEntity.ok(restTemplate.getForObject(fullUrl, Object.class));
                case "POST":
                    return ResponseEntity.ok(restTemplate.postForObject(fullUrl, body, Object.class));
                case "PUT":
                    restTemplate.put(fullUrl, body);
                    return ResponseEntity.ok().build();
                case "DELETE":
                    restTemplate.delete(fullUrl);
                    return ResponseEntity.ok().build();
                default:
                    return ResponseEntity.badRequest().build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Service unavailable: " + e.getMessage());
        }
    }
}
