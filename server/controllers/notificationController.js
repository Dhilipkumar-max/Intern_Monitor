const db = require('../config/db');

exports.getStudentNotifications = async (req, res) => {
    const { studentId } = req.params;

    try {
        const [rows] = await db.execute(
            'SELECT * FROM notifications WHERE student_id = ? ORDER BY created_at DESC',
            [studentId]
        );
        res.json(rows);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching notifications', error: err.message });
    }
};

exports.markAsRead = async (req, res) => {
    const { id } = req.params;

    try {
        await db.execute('UPDATE notifications SET status = "Read" WHERE id = ?', [id]);
        res.json({ message: 'Notification marked as read' });
    } catch (err) {
        res.status(500).json({ message: 'Error updating notification', error: err.message });
    }
};

exports.createNotification = async (req, res) => {
    const { student_id, title, message, type } = req.body;
    try {
        await db.execute(
            'INSERT INTO notifications (student_id, title, message, type) VALUES (?, ?, ?, ?)',
            [student_id, title, message, type || 'admin_message']
        );
        res.status(201).json({ message: 'Notification sent successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error sending notification', error: err.message });
    }
};
