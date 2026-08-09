package com.smartlearning.aspect;

import com.smartlearning.annotation.RequireRole;
import com.smartlearning.exception.BusinessException;
import jakarta.servlet.http.HttpServletRequest;
import java.util.Arrays;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * 角色校验：读取 JwtInterceptor 写入的 role 请求属性，
 * 不在允许列表内则抛出 403（由全局异常处理器转成 HTTP 403）。
 */
@Aspect
@Component
public class RoleCheckAspect {

    @Before("@annotation(requireRole)")
    public void checkRole(RequireRole requireRole) {
        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        HttpServletRequest request = attrs != null ? attrs.getRequest() : null;
        String role = request != null ? (String) request.getAttribute("role") : null;
        if (role == null || Arrays.stream(requireRole.value()).noneMatch(role::equalsIgnoreCase)) {
            throw new BusinessException(403, "无权限执行该操作");
        }
    }
}
