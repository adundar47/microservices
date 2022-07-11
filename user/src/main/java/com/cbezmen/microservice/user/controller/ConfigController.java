package com.cbezmen.microservice.user.controller;

import com.cbezmen.core.library.config.MessageProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author canbezmen
 */
@Slf4j
@RestController
public class ConfigController {

	@Autowired
	private MessageProperties messageProperties;

	@Value("${VERSION}")
	private String version;

	@GetMapping(value = "/config", produces = MediaType.APPLICATION_JSON_VALUE)
	public String getMessage() {
		return messageProperties.toString();
	}

	@GetMapping("/ping")
	public String ping() {
		return "I'm user-service " + version;
	}
}
