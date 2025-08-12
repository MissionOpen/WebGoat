/*
 * SPDX-FileCopyrightText: Copyright © 2017 WebGoat authors
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
package org.owasp.webgoat.container.users;

import java.util.List;
import java.util.function.Function;
import lombok.AllArgsConstructor;
import org.flywaydb.core.Flyway;
import org.owasp.webgoat.container.lessons.Initializable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.context.ApplicationEventPublisher;

@Service
@AllArgsConstructor
public class UserService implements UserDetailsService {
  private final UserRepository userRepository;
  private final UserProgressRepository userTrackerRepository;
  private final JdbcTemplate jdbcTemplate;
  private final Function<String, Flyway> flywayLessons;
  // private final List<Initializable> lessonInitializables; // can be removed if not used elsewhere
  private final ApplicationEventPublisher eventPublisher;
  private final List<Initializable> lessonInitializables;

  @Override
  public WebGoatUser loadUserByUsername(String username) throws UsernameNotFoundException {
    if (userRepository == null) {
      throw new UsernameNotFoundException("User repository is not available");
    }
    WebGoatUser webGoatUser = userRepository.findByUsername(username);
    WebGoatUser webGoatUser = userRepository.findByUsername(username);
    if (webGoatUser == null) {
      throw new UsernameNotFoundException("User not found");
    }
    // Publish an event to initialize lessons for the user to keep dependencies low
    eventPublisher.publishEvent(new UserInitializedEvent(webGoatUser));
    lessonInitializables.forEach(l -> l.initialize(webGoatUser));
    return webGoatUser;
  }

  /**
   * Adds a new user with the specified username and password.
   * If the user does not already exist, also creates a user progress tracker and initializes lessons for the user.
   *
   * @param username the username of the new user
   * @param password the password of the new user
   * @throws IllegalStateException if the user repository or user tracker repository is not available
   */
  public void addUser(String username, String password) {
    if (userRepository == null || userTrackerRepository == null) {
      throw new IllegalStateException("User repository or user tracker repository is not available");
    }
    // get user if there exists one by the name
    var userAlreadyExists = userRepository.existsByUsername(username);
    var webGoatUser = userRepository.save(new WebGoatUser(username, password));

    if (!userAlreadyExists) {
      userTrackerRepository.save(
          new UserProgress(username)); // if user previously existed it will not get another tracker
      createLessonsForUser(webGoatUser);
    }
  }

  private void createLessonsForUser(WebGoatUser webGoatUser) {
    if (jdbcTemplate != null) {
      String username = webGoatUser.getUsername();
      // Only allow alphanumeric and underscore for schema names to prevent SQL injection
      if (username != null && username.matches("[A-Za-z0-9_]+")) {
        try {
          jdbcTemplate.execute("CREATE SCHEMA \"" + username + "\" authorization dba");
        } catch (Exception e) {
          // Log the exception or handle it as needed, e.g., schema may already exist
          // For now, just ignore if schema exists
        }
      } else {
        // Handle invalid username case
        throw new IllegalArgumentException("Invalid username for schema creation");
      }
    }
    if (flywayLessons != null) {
      flywayLessons.apply(webGoatUser.getUsername()).migrate();
    }
  }

  public List<WebGoatUser> getAllUsers() {
    return userRepository.findAll();
  }
}



