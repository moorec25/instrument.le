"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const app = (0, express_1.default)();
const port = 3000;
app.get('/startGame', (req, res) => {
    console.log('Client requesting metadata...');
    // TODO: Get metadata from a database
    let metadata = {
        songId: 1,
        songName: 'Smells Like Teen Spirit',
        artistName: 'Nirvana',
        albumName: 'Nevermind',
        albumCover: 'https://upload.wikimedia.org/wikipedia/en/b/b7/NirvanaNevermindalbumcover.jpg',
        year: '1991',
        genre: 'Grunge',
        filepath: '../songs/Nirvana/Smells_Like_Teen_Spirit',
        files: ['bass.wav', 'drums.wav', 'mixture.wav', 'vocals.wav', 'other.wav']
    };
    res.json(metadata);
});
app.get('/audio/:id/:filename', (req, res) => {
    console.log(`Client requesting audio file ${req.params.filename}...`);
    // TODO: Use the id to get the song metadata
    const fileName = req.params.filename;
    const filePath = path_1.default.join(__dirname, '../songs/Nirvana/Smells_Like_Teen_Spirit', fileName);
    // Ensure the file exists
    if (!fs_1.default.existsSync(filePath)) {
        res.status(404).send('Not found');
        return;
    }
    // Set header and stream the file
    res.setHeader('Content-Type', 'audio/wav');
    // Create read stream
    const audioStream = fs_1.default.createReadStream(filePath);
    // Pipe the read stream to the response
    audioStream.on('open', () => {
        audioStream.pipe(res);
    });
    // End the response when the stream ends
    audioStream.on('end', () => {
        res.end();
    });
    // Handle errors
    audioStream.on('error', (streamErr) => {
        res.end(streamErr);
    });
});
app.listen(port, () => {
    console.log(`Listening on port ${port}`);
});
