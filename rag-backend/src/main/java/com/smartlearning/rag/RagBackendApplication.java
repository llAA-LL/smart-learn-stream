package com.smartlearning.rag;

import com.smartlearning.rag.config.RagProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties(RagProperties.class)
public class RagBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(RagBackendApplication.class, args);
    }
}
