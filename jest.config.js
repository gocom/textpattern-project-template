module.exports = {
    moduleFileExtensions: [
        'js',
        'json',
    ],
    transform: {
        '.*\\.(js)$': 'babel-jest',
    },
    collectCoverage: true,
    collectCoverageFrom: [
        'assets/js/**/*.js',
        '!src/vendor/**/*',
        '!src/components/**/*/main.js',
    ],
    moduleNameMapper: {
        '.*\\.(jpg|png|svg)$': '<rootDir>/tests/js/mocks/file.js',
        '.*\\.(css|less)$': '<rootDir>/tests/js/mocks/style.js',
    },
    setupFiles: [
        '<rootDir>/tests/js/mocks/localStorage.js',
    ],
};
