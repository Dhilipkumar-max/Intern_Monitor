const db = require('../config/db');

exports.getAllSkills = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM skills');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching skills', error: err.message });
    }
};

exports.addStudentSkill = async (req, res) => {
    const { student_id, skill_name, level } = req.body;

    try {
        // 1. Get or create skill_id
        let [skills] = await db.execute('SELECT id FROM skills WHERE skill_name = ?', [skill_name]);
        let skillId;

        if (skills.length === 0) {
            const [result] = await db.execute('INSERT INTO skills (skill_name) VALUES (?)', [skill_name]);
            skillId = result.insertId;
        } else {
            skillId = skills[0].id;
        }

        // 2. Check if student already has this skill
        const [existing] = await db.execute('SELECT id FROM student_skills WHERE student_id = ? AND skill_id = ?', [student_id, skillId]);

        if (existing.length > 0) {
            await db.execute('UPDATE student_skills SET skill_level = ? WHERE id = ?', [level || 'Beginner', existing[0].id]);
            return res.json({ message: 'Skill level updated' });
        }

        // 3. Link student and skill
        await db.execute('INSERT INTO student_skills (student_id, skill_id, skill_level) VALUES (?, ?, ?)', [student_id, skillId, level || 'Beginner']);
        res.status(201).json({ message: 'Skill added to student profile' });
    } catch (err) {
        res.status(500).json({ message: 'Error adding skill', error: err.message });
    }
};

exports.getStudentSkills = async (req, res) => {
    const { studentId } = req.params;
    try {
        const [rows] = await db.execute(`
            SELECT sk.id, sk.skill_name, ss.skill_level as level 
            FROM student_skills ss 
            JOIN skills sk ON ss.skill_id = sk.id 
            WHERE ss.student_id = ?
        `, [studentId]);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching student skills', error: err.message });
    }
};

exports.updateStudentSkill = async (req, res) => {
    const { student_id, skill_id, level } = req.body;
    try {
        await db.execute('UPDATE student_skills SET skill_level = ? WHERE student_id = ? AND skill_id = ?', [level, student_id, skill_id]);
        res.json({ message: 'Skill updated successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error updating skill', error: err.message });
    }
};

exports.deleteStudentSkill = async (req, res) => {
    const { id } = req.params;
    try {
        await db.execute('DELETE FROM student_skills WHERE id = ?', [id]);
        res.json({ message: 'Skill removed from profile' });
    } catch (err) {
        res.status(500).json({ message: 'Error deleting skill', error: err.message });
    }
};
