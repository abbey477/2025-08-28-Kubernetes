package com.example.productservice.service;

import com.example.productservice.model.Product;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;

@Service
public class ProductService {
    private Map<Long, Product> products = new HashMap<>();
    private Long nextId = 1L;

    public ProductService() {
        // Initialize with sample data
        products.put(1L, new Product(1L, "Laptop", "Gaming Laptop", new BigDecimal("999.99"), 10));
        products.put(2L, new Product(2L, "Mouse", "Wireless Mouse", new BigDecimal("29.99"), 50));
        nextId = 3L;
    }

    public List<Product> getAllProducts() {
        return new ArrayList<>(products.values());
    }

    public Product getProductById(Long id) {
        return products.get(id);
    }

    public Product createProduct(Product product) {
        product.setId(nextId++);
        products.put(product.getId(), product);
        return product;
    }

    public Product updateStock(Long id, Integer quantity) {
        Product product = products.get(id);
        if (product != null) {
            product.setStock(product.getStock() - quantity);
        }
        return product;
    }
}
