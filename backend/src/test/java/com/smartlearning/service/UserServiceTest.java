package com.smartlearning.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.smartlearning.dto.LoginRequest;
import com.smartlearning.dto.RegisterRequest;
import com.smartlearning.entity.User;
import com.smartlearning.exception.BusinessException;
import com.smartlearning.mapper.UserMapper;
import com.smartlearning.util.JwtUtil;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    private static final BCryptPasswordEncoder ENCODER = new BCryptPasswordEncoder();

    @Mock
    private UserMapper userMapper;

    @Mock
    private JwtUtil jwtUtil;

    private UserService service() {
        return new UserService(userMapper, jwtUtil);
    }

    private User user(String username, String password, String role) {
        User u = new User();
        u.setId(1L);
        u.setUsername(username);
        u.setPassword(password);
        u.setRole(role);
        return u;
    }

    @Test
    void loginSucceedsWithBcryptPassword() {
        when(userMapper.findByUsername("zhangsan"))
                .thenReturn(user("zhangsan", ENCODER.encode("123456"), "STUDENT"));
        when(jwtUtil.generateToken(1L, "zhangsan", "STUDENT")).thenReturn("token");
        LoginRequest req = new LoginRequest();
        req.setUsername("zhangsan");
        req.setPassword("123456");

        var resp = service().login(req);

        assertThat(resp.getToken()).isEqualTo("token");
        assertThat(resp.getRole()).isEqualTo("STUDENT");
    }

    @Test
    void loginFailsWithWrongPassword() {
        when(userMapper.findByUsername("zhangsan"))
                .thenReturn(user("zhangsan", ENCODER.encode("123456"), "STUDENT"));
        LoginRequest req = new LoginRequest();
        req.setUsername("zhangsan");
        req.setPassword("wrong-password");

        assertThatThrownBy(() -> service().login(req))
                .isInstanceOf(BusinessException.class);
        verify(jwtUtil, never()).generateToken(anyLong(), anyString(), anyString());
    }

    @Test
    void loginFailsWhenUserMissing() {
        when(userMapper.findByUsername("nobody")).thenReturn(null);
        LoginRequest req = new LoginRequest();
        req.setUsername("nobody");
        req.setPassword("123456");

        assertThatThrownBy(() -> service().login(req)).isInstanceOf(BusinessException.class);
    }

    @Test
    void registerForcesStudentRoleAndHidesPassword() {
        when(userMapper.findByUsername("newuser")).thenReturn(null);
        RegisterRequest req = new RegisterRequest();
        req.setUsername("newuser");
        req.setPassword("123456");
        req.setRealName("新同学");

        User result = service().register(req);

        assertThat(result.getRole()).isEqualTo("STUDENT");
        assertThat(result.getPassword()).isNull();
        verify(userMapper).insert(argThat(u ->
                "STUDENT".equals(u.getRole())
                        && ENCODER.matches("123456", u.getPassword())));
    }

    @Test
    void registerRejectsDuplicateUsername() {
        when(userMapper.findByUsername("dup")).thenReturn(user("dup", "x", "STUDENT"));
        RegisterRequest req = new RegisterRequest();
        req.setUsername("dup");
        req.setPassword("123456");

        assertThatThrownBy(() -> service().register(req)).isInstanceOf(BusinessException.class);
        verify(userMapper, never()).insert(any());
    }
}
