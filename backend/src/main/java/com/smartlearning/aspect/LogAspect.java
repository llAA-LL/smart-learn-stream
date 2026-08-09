package com.smartlearning.aspect;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.UUID;

@Aspect
@Component
public class LogAspect {

    private static final Logger log = LoggerFactory.getLogger(LogAspect.class);
    private static final ObjectMapper mapper = new ObjectMapper()
            .registerModule(new JavaTimeModule());

    @Around("execution(* com.smartlearning.controller..*(..))")
    public Object logController(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        HttpServletRequest request = getRequest();
        String method = request != null ? request.getMethod() : "?";
        String uri = request != null ? request.getRequestURI() : "?";
        String traceId = UUID.randomUUID().toString().substring(0, 8);
        String signature = joinPoint.getSignature().toShortString();

        String args = truncate(mapper.writeValueAsString(joinPoint.getArgs()), 500);

        log.info("[{}] --> {} {} | {}", traceId, method, uri, signature);
        log.debug("[{}]    params: {}", traceId, args);

        Object result;
        try {
            result = joinPoint.proceed();
        } catch (Throwable e) {
            long elapsed = System.currentTimeMillis() - start;
            log.error("[{}] <-- {} {} FAILED ({}ms) | {}: {}",
                    traceId, method, uri, elapsed,
                    e.getClass().getSimpleName(), e.getMessage());
            throw e;
        }

        long elapsed = System.currentTimeMillis() - start;
        String resp = truncate(mapper.writeValueAsString(result), 300);
        log.info("[{}] <-- {} {} OK ({}ms)", traceId, method, uri, elapsed);
        log.debug("[{}]    result: {}", traceId, resp);
        return result;
    }

    private HttpServletRequest getRequest() {
        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attrs != null ? attrs.getRequest() : null;
    }

    private String truncate(String s, int maxLen) {
        return s.length() > maxLen ? s.substring(0, maxLen) + "..." : s;
    }
}
