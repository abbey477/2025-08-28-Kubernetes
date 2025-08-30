package com.example.notificationservice.model;

import java.time.LocalDateTime;

public class Notification {
    private Long id;
    private Long userId;
    private String message;
    private String status;
    private LocalDateTime createdAt;

    public Notification() {}

    public Notification(Long id, Long userId, String message, String status) {
        this.id = id;
        this.userId = userId;
        this.message = message;
        this.status = status;
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}