const pool = require('../config/db');

class SpamMessage {
    static async create({
        user_id,
        phone_number,
        message_text,
        detection_method,
        threat_level,
        ai_confidence = null,
        ml_confidence = null
    }) {
        const query = `
            INSERT INTO spam_messages (
                user_id, phone_number, message_text, detection_method,
                threat_level, ai_confidence, ml_confidence
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING *;
        `;
        const values = [
            user_id, phone_number, message_text, detection_method,
            threat_level, ai_confidence, ml_confidence
        ];
        const { rows } = await pool.query(query, values);
        return rows[0];
    }

    static async findByUserId(user_id, { limit = 50, offset = 0, unreadOnly = false } = {}) {
        let query = `
            SELECT * FROM spam_messages
            WHERE user_id = $1
        `;

        if (unreadOnly) {
            query += ' AND is_read = false';
        }

        query += `
            ORDER BY detected_at DESC
            LIMIT $2 OFFSET $3;
        `;

        const { rows } = await pool.query(query, [user_id, limit, offset]);
        return rows;
    }

    static async findById(id, user_id) {
        const query = `
            SELECT * FROM spam_messages
            WHERE id = $1 AND user_id = $2;
        `;
        const { rows } = await pool.query(query, [id, user_id]);
        return rows[0];
    }

    static async markAsRead(id, user_id) {
        const query = `
            UPDATE spam_messages
            SET is_read = true
            WHERE id = $1 AND user_id = $2
            RETURNING *;
        `;
        const { rows } = await pool.query(query, [id, user_id]);
        return rows[0];
    }

    static async markAsFalsePositive(id, user_id) {
        const query = `
            UPDATE spam_messages
            SET is_false_positive = true
            WHERE id = $1 AND user_id = $2
            RETURNING *;
        `;
        const { rows } = await pool.query(query, [id, user_id]);
        return rows[0];
    }

    static async getStats(user_id) {
        const query = `
            SELECT
                COUNT(*) as total,
                COUNT(*) FILTER (WHERE is_read = false) as unread,
                COUNT(*) FILTER (WHERE threat_level = 'high') as high_threat,
                COUNT(*) FILTER (WHERE threat_level = 'medium') as medium_threat,
                COUNT(*) FILTER (WHERE threat_level = 'low') as low_threat,
                COUNT(*) FILTER (WHERE detected_at >= CURRENT_DATE) as today,
                COUNT(*) FILTER (WHERE detected_at >= CURRENT_DATE - INTERVAL '7 days') as this_week
            FROM spam_messages
            WHERE user_id = $1;
        `;
        const { rows } = await pool.query(query, [user_id]);
        return rows[0];
    }

    static async deleteById(id, user_id) {
        const query = `
            DELETE FROM spam_messages
            WHERE id = $1 AND user_id = $2
            RETURNING id;
        `;
        const { rows } = await pool.query(query, [id, user_id]);
        return rows[0];
    }
}

module.exports = SpamMessage;
