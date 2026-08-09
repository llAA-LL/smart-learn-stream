package com.smartlearning.aspect;

import com.smartlearning.annotation.RateLimit;
import com.smartlearning.exception.BusinessException;
import com.smartlearning.util.RedisUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.concurrent.TimeUnit;

/**
 * Sliding-window rate limiter using Redis.
 * Key format: rate_limit:{ip}:{methodKey}
 */
@Aspect
@Component
public class RateLimitAspect {

    private static final Logger log = LoggerFactory.getLogger(RateLimitAspect.class);

    private final RedisUtil redisUtil;

    public RateLimitAspect(RedisUtil redisUtil) {
        this.redisUtil = redisUtil;
    }

    @Around("@annotation(rateLimit)")
    public Object around(ProceedingJoinPoint joinPoint, RateLimit rateLimit) throws Throwable {
        HttpServletRequest request = getRequest();
        String ip = getClientIp(request);
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        String methodKey = rateLimit.key().isEmpty()
                ? signature.getMethod().getName()
                : rateLimit.key();
        String key = "rate_limit:" + ip + ":" + methodKey;

        long current = redisUtil.increment(key);
        if (current == 1) {
            redisUtil.expire(key, rateLimit.window(), TimeUnit.SECONDS);
        }
        if (current > rateLimit.value()) {
            log.warn("限流触发: ip={}, key={}, count={}/{}, window={}s",
                    ip, methodKey, current, rateLimit.value(), rateLimit.window());
            throw new BusinessException(429,
                    "请求过于频繁，请" + rateLimit.window() + "秒后再试");
        }
        return joinPoint.proceed();
    }

    private HttpServletRequest getRequest() {
        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs == null) {
            throw new BusinessException(500, "无法获取请求上下文");
        }
        return attrs.getRequest();
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // Multiple proxies: first one is the real client
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }
}
