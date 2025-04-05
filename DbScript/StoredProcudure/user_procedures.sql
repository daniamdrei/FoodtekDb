DELIMITER //

-- Register new user
CREATE PROCEDURE sp_RegisterUser(
    IN p_name VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_phone VARCHAR(15),
    IN p_password VARCHAR(255),
    IN p_role ENUM('Admin','Client','Delivery'),
    OUT p_user_id BIGINT
)
BEGIN
    INSERT INTO users (name, email, phone, password, role, created_at, updated_at)
    VALUES (p_name, p_email, p_phone, p_password, p_role, NOW(), NOW());
    
    SET p_user_id = LAST_INSERT_ID();
END //

-- Authenticate user
CREATE PROCEDURE sp_AuthenticateUser(
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    OUT p_user_id BIGINT,
    OUT p_role VARCHAR(50),
    OUT p_result BOOLEAN
)
BEGIN
    DECLARE user_count INT;
    
    SELECT COUNT(*), id, role INTO user_count, p_user_id, p_role
    FROM users
    WHERE email = p_email AND password = p_password;
    
    IF user_count = 1 THEN
        SET p_result = TRUE;
        UPDATE users SET last_login = NOW() WHERE id = p_user_id;
    ELSE
        SET p_result = FALSE;
        SET p_user_id = NULL;
        SET p_role = NULL;
    END IF;
END //

-- Update user profile
CREATE PROCEDURE sp_UpdateUserProfile(
    IN p_user_id BIGINT,
    IN p_name VARCHAR(255),
    IN p_phone VARCHAR(15),
    IN p_birthday DATE,
    IN p_profile_picture VARCHAR(255)
)
BEGIN
    UPDATE users
    SET 
        name = p_name,
        phone = p_phone,
        birthday = p_birthday,
        profile_picture = p_profile_picture,
        updated_at = NOW()
    WHERE id = p_user_id;
END //

DELIMITER ;