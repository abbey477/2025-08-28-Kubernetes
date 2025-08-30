package com.example.userservice.service;

import com.example.userservice.model.User;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class UserService {
    private Map<Long, User> users = new HashMap<>();
    private Long nextId = 1L;

    public UserService() {
        // Initialize with sample data
        users.put(1L, new User(1L, "John Doe", "john@example.com"));
        users.put(2L, new User(2L, "Jane Smith", "jane@example.com"));
        nextId = 3L;
    }

    public List<User> getAllUsers() {
        return new ArrayList<>(users.values());
    }

    public User getUserById(Long id) {
        return users.get(id);
    }

    public User createUser(User user) {
        user.setId(nextId++);
        users.put(user.getId(), user);
        return user;
    }
}