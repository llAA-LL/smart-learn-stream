package com.smartlearning.rag.annotation;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Redis 固定窗口限流（按客户端 IP）。
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RateLimit {

    /** 窗口内最大请求数 */
    int value() default 60;

    /** 窗口时长（秒） */
    int window() default 60;
}
