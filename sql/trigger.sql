
create function update_message_statistics() returns trigger as $message_stat$
    BEGIN
        <<insert_update>>
        LOOP
            UPDATE user_statistics
            SET    num_messages = num_messages + 1
            WHERE  sender_id = NEW.sender_id
             AND   recipient_id = NEW.recipient_id
             AND   period = date_trunc('month', NEW.message_date);
        EXIT insert_update WHEN found;

        BEGIN
            INSERT INTO user_statistics (
                sender_id,
                recipient_id,
                num_messages,
                period)
            VALUES (
                NEW.sender_id,
                NEW.recipient_id,
                1,
                date_trunc('month', NEW.message_date)
            );
            EXIT insert_update;
        EXCEPTION
            WHEN UNIQUE_VIOLATION THEN
                -- do nothing
        END;
    END LOOP insert_update;

    RETURN NULL;

    END;
$message_stat$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_statistics
AFTER INSERT ON messages
    FOR EACH ROW EXECUTE PROCEDURE update_message_statistics();
