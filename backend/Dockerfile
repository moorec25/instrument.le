# Step 1: Choose Base Image
FROM node:20

# Step 2: Set Working Directory
WORKDIR /usr/src/app

# Step 3: Copy package.json and package-lock.json
COPY package*.json ./

# Step 4: Install Dependencies
RUN npm install

# Step 5: Copy App Source
COPY . .

# Step 6: Expose Port
EXPOSE 3000

# Step 7: Start the App
CMD ["node", "index.js"]
