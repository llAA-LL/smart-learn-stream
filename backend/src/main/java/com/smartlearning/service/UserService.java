package com.smartlearning.service;

import com.smartlearning.dto.LoginRequest;
import com.smartlearning.dto.LoginResponse;
import com.smartlearning.dto.RegisterRequest;
import com.smartlearning.entity.User;
import com.smartlearning.exception.BusinessException;
import com.smartlearning.mapper.UserMapper;
import com.smartlearning.util.JwtUtil;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@Service
public class UserService {

    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public UserService(UserMapper userMapper, JwtUtil jwtUtil) {
        this.userMapper = userMapper;
        this.jwtUtil = jwtUtil;
    }

    public LoginResponse login(LoginRequest request) {
        User user = userMapper.findByUsername(request.getUsername());
        if (user == null) {
            throw new BusinessException(401, "用户名或密码错误");
        }
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException(401, "用户名或密码错误");
        }
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
        return new LoginResponse(token, user.getId(), user.getUsername(), user.getRealName(), user.getRole());
    }

    public User register(RegisterRequest request) {
        User exist = userMapper.findByUsername(request.getUsername());
        if (exist != null) {
            throw new BusinessException(400, "用户名已存在");
        }
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        // 角色强制为 STUDENT，防止客户端注册时注入 ADMIN
        user.setRole("STUDENT");
        user.setRealName(request.getRealName());
        userMapper.insert(user);
        // 返回脱敏副本，避免修改已持久化对象
        User response = new User();
        response.setId(user.getId());
        response.setUsername(user.getUsername());
        response.setRealName(user.getRealName());
        response.setRole(user.getRole());
        return response;
    }

    public User getById(Long id) {
        User user = userMapper.findById(id);
        if (user == null) {
            throw new BusinessException(404, "用户不存在");
        }
        user.setPassword(null);
        return user;
    }

}
