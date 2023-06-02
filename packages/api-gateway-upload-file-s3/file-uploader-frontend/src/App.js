import './App.css';
import { useFilePicker } from 'use-file-picker';
import axios from 'axios';
const mime = require('mime');

const sendFile = (plainFiles, filesContent) => {
  console.log(plainFiles)
  if(!plainFiles || plainFiles.length === 0){
    alert('No files selected')
  }else{
    const chunkName = plainFiles[0].name.split('.');
    const contentType = mime.getType(chunkName[1])
    axios.get(`https://69ybx6umo1.execute-api.eu-west-1.amazonaws.com/prod/Item?filename=${chunkName[0]}&content-type=${contentType}`).then(
      (result) => {
        console.log(result)
        const {uploadURL} = result.data
        axios.put(uploadURL, filesContent, {headers: {contentType}}).then(
          (result2) => {
            alert("File succesfuly sent")
          }
        )
      }
    )
  }
}

function App() {
  const [openFileSelector, { filesContent, loading, plainFiles }] = useFilePicker({
    accept: ['.txt', '.jpeg'],
    onFilesSuccessfulySelected: ({ plainFiles, filesContent }) => {
      // this callback is called when there were no validation errors
      console.log('File selected!', plainFiles, filesContent);
    },
  });

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <button onClick={() => openFileSelector()}>Select files </button>
      <button onClick={() => sendFile(plainFiles, filesContent)}>Send selected file </button>
      <br />
      {filesContent.map((file, index) => (
        <div>
          <h2>{file.name}</h2>
          <div key={index}>{file.content}</div>
          <br />
        </div>
      ))}
    </div>
  );
}

export default App;
