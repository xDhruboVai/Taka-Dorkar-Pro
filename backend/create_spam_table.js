const pool = require('./config/db');

async function createSpamMessagesTable() {
    try {
        await pool.query('BEGIN');

        console.log('Creating spam_messages table...');

        await pool.query(`
            CREATE TABLE IF NOT EXISTS spam_messages (
                id SERIAL PRIMARY KEY,
                user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                phone_number VARCHAR(20) NOT NULL,
                message_text TEXT NOT NULL,
                detection_method VARCHAR(20) NOT NULL CHECK (detection_method IN ('ml', 'ai', 'both')),
                threat_level VARCHAR(20) NOT NULL CHECK (threat_level IN ('low', 'medium', 'high')),
                ai_confidence DECIMAL(5,2),
                ml_confidence DECIMAL(5,2),
                detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                is_read BOOLEAN DEFAULT FALSE,
                is_false_positive BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);

        console.log('Creating indexes...');

        await pool.query(`
            CREATE INDEX IF NOT EXISTS idx_spam_user_id ON spam_messages(user_id);
        `);

        await pool.query(`
            CREATE INDEX IF NOT EXISTS idx_spam_detected_at ON spam_messages(detected_at DESC);
        `);

        await pool.query(`
            CREATE INDEX IF NOT EXISTS idx_spam_threat_level ON spam_messages(threat_level);
        `);

        await pool.query('COMMIT');

        console.log('✅ spam_messages table created successfully!');

    } catch (error) {
        await pool.query('ROLLBACK');
        console.error('Error creating spam_messages table:', error);
        throw error;
    } finally {
        await pool.end();
    }
}

createSpamMessagesTable()
    .then(() => {
        console.log('Migration completed successfully');
        process.exit(0);
    })
    .catch((error) => {
        console.error('Migration failed:', error);
        process.exit(1);
    });
