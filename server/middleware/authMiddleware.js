const jwt = require('jsonwebtoken');
require('dotenv').config();

const verifyToken = (req, res, next) => {
    const token = req.headers['authorization'];

    if (!token) {
        return res.status(403).json({ message: 'No token provided' });
    }

    try {
        const bearerToken = token.split(' ')[1];
        const decoded = jwt.verify(bearerToken, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        return res.status(401).json({ message: 'Unauthorized' });
    }
};

const isAdmin = (req, res, next) => {
    if (req.user && (req.user.role === 'Admin' || req.user.isAdmin)) {
        next();
    } else {
        res.status(403).json({ message: 'Require Admin Role' });
    }
};

module.exports = { verifyToken, isAdmin };
