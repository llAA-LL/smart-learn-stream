package com.smartlearning.controller;

import com.smartlearning.annotation.RateLimit;
import com.smartlearning.dto.ApiResponse;
import com.smartlearning.dto.LoginRequest;
import com.smartlearning.dto.LoginResponse;
import com.smartlearning.dto.RegisterRequest;
import com.smartlearning.entity.User;
import com.smartlearning.service.TokenBlacklistService;
import com.smartlearning.service.UserService;
import com.smartlearning.util.JwtUtil;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.Date;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;
    private final TokenBlacklistService blacklistService;
    private final JwtUtil jwtUtil;

    public AuthController(UserService userService, TokenBlacklistService blacklistService, JwtUtil jwtUtil) {
        this.userService = userService;
        this.blacklistService = blacklistService;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/login")
    @RateLimit(value = 10, window = 60, key = "login")
    public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok(userService.login(request));
    }

    @PostMapping("/register")
    @RateLimit(value = 5, window = 60, key = "register")
    public ApiResponse<User> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.ok(userService.register(request));
    }

    @GetMapping("/me")
    public ApiResponse<User> me(@RequestAttribute("userId") Long userId) {
        return ApiResponse.ok(userService.getById(userId));
    }

    @PostMapping("/logout")
    public ApiResponse<?> logout(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            try {
                Claims claims = jwtUtil.parseToken(token);
                long remainingMs = claims.getExpiration().getTime() - System.currentTimeMillis();
                blacklistService.blacklist(token, remainingMs / 1000);
            } catch (Exception ignored) {
                // Token already invalid, no need to blacklist
            }
        }
        return ApiResponse.ok();
    }
}
