import express, { Request, Response } from 'express';
import fs from 'fs';
import path from 'path';

const app = express();

const port = 3000;

app.get('/startGame', (req: Request, res: Response) => {
	console.log('Client requesting metadata...')
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
	}
	res.json(metadata);
});

app.get('/audio/:id/:filename', (req: Request, res: Response) => {
	console.log(`Client requesting audio file ${req.params.filename}...`)
	// TODO: Use the id to get the song metadata from database
	const fileName = req.params.filename;
	const filePath = path.join(__dirname, '../songs/Nirvana/Smells_Like_Teen_Spirit', fileName);
	// Ensure the file exists
	if (!fs.existsSync(filePath)) {
		res.status(404).send('Not found');
		return;
	}
	// Set header and stream the file
	res.setHeader('Content-Type', 'audio/wav');
	// Create read stream
	const audioStream = fs.createReadStream(filePath);
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