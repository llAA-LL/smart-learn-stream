package com.smartlearning.annotation;

import java.lang.annotation.*;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RateLimit {
    /** max requests allowed in the time window */
    int value() default 60;
    /** time window in seconds */
    int window() default 60;
    /** key prefix, defaults to method name */
    String key() default "";
}
