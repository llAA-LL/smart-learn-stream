package com.smartlearning.aspect;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.smartlearning.annotation.RequireRole;
import com.smartlearning.exception.BusinessException;
import java.lang.reflect.Proxy;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

class RoleCheckAspectTest {

    private final RoleCheckAspect aspect = new RoleCheckAspect();

    @AfterEach
    void reset() {
        RequestContextHolder.resetRequestAttributes();
    }

    private void setRole(String role) {
        MockHttpServletRequest request = new MockHttpServletRequest();
        if (role != null) {
            request.setAttribute("role", role);
        }
        RequestContextHolder.setRequestAttributes(new ServletRequestAttributes(request));
    }

    private RequireRole requireRole(String... roles) {
        return (RequireRole) Proxy.newProxyInstance(
                getClass().getClassLoader(),
                new Class<?>[]{RequireRole.class},
                (proxy, method, args) -> "value".equals(method.getName()) ? roles : null);
    }

    @Test
    void adminRolePasses() {
        setRole("ADMIN");
        assertThatCode(() -> aspect.checkRole(requireRole("ADMIN"))).doesNotThrowAnyException();
    }

    @Test
    void studentRoleIsRejected() {
        setRole("STUDENT");
        assertThatThrownBy(() -> aspect.checkRole(requireRole("ADMIN")))
                .isInstanceOf(BusinessException.class);
    }

    @Test
    void missingRoleIsRejected() {
        setRole(null);
        assertThatThrownBy(() -> aspect.checkRole(requireRole("ADMIN")))
                .isInstanceOf(BusinessException.class);
    }
}
