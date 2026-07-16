package com.applicationtracker.backend.service;

import com.applicationtracker.backend.dto.LoginRequest;
import com.applicationtracker.backend.dto.RegisterRequest;
import com.applicationtracker.backend.model.User;
import com.applicationtracker.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User register(RegisterRequest request) {
        // 1. Check if email already exists
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new IllegalArgumentException("Email is already in use");
        }

        // 2. Hash the raw password
        String hashedPassword = passwordEncoder.encode(request.getPassword());

        // 3. Create and save the new User
        User user = new User(
            request.getName(),
            request.getEmail(),
            hashedPassword
        );

        return userRepository.save(user);
    }

    public User login(LoginRequest request) {
        // 1. Find user by email
        User user = userRepository.findByEmail(request.getEmail())
            .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));

        // 2. Match raw password against database hash
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Invalid email or password");
        }

        // Return user details upon successful login
        return user;
    }
}
