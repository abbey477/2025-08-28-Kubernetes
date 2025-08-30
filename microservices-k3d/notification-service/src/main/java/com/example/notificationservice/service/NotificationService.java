package com.example.notificationservice.service;

import com.example.notificationservice.model.Notification;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class NotificationService {
    private Map<Long, Notification> notifications = new HashMap<>();
    private Long nextId = 1L;

    public List<Notification> getAllNotifications() {
        return new ArrayList<>(notifications.values());
    }

    public List<Notification> getNotificationsByUserId(Long userId) {
        return notifications.values().stream()
                .filter(n -> n.getUserId().equals(userId))
                .collect(Collectors.toList());
    }

    public Notification sendNotification(Notification notification) {
        notification.setId(nextId++);
        notification.setStatus("SENT");
        notifications.put(notification.getId(), notification);

        System.out.println("Notification sent: " + notification.getMessage());

        return notification;
    }
}