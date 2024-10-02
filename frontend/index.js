import { backend } from 'declarations/backend';

const inputText = document.getElementById('input-text');
const languageSelect = document.getElementById('language-select');
const outputText = document.getElementById('output-text');
const speakButton = document.getElementById('speak-button');
const historyList = document.getElementById('history-list');

let translationTimeout;

async function translateText() {
  const text = inputText.value;
  const targetLang = languageSelect.value;

  if (text.trim() === '') {
    outputText.value = '';
    return;
  }

  try {
    const response = await fetch(`https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=en|${targetLang}`);
    const data = await response.json();

    if (data.responseStatus === 200) {
      const translatedText = data.responseData.translatedText;
      outputText.value = translatedText;

      // Add translation to backend
      await backend.addTranslation(text, translatedText, targetLang);

      // Update history
      updateTranslationHistory();
    } else {
      throw new Error('Translation failed');
    }
  } catch (error) {
    console.error('Error:', error);
    outputText.value = 'Error: Could not translate text';
  }
}

function debounceTranslation() {
  clearTimeout(translationTimeout);
  translationTimeout = setTimeout(translateText, 300);
}

async function updateTranslationHistory() {
  const history = await backend.getTranslationHistory();
  historyList.innerHTML = '';
  history.forEach(item => {
    const li = document.createElement('li');
    li.textContent = `${item.original} -> ${item.translated} (${item.language})`;
    historyList.appendChild(li);
  });
}

function speakTranslation() {
  const text = outputText.value;
  if (text) {
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = languageSelect.value;
    speechSynthesis.speak(utterance);
  }
}

inputText.addEventListener('input', debounceTranslation);
languageSelect.addEventListener('change', translateText);
speakButton.addEventListener('click', speakTranslation);

// Initial history update
updateTranslationHistory();
