document.addEventListener('DOMContentLoaded', () => {
  const toggleButton = document.createElement('button');
  toggleButton.className = 'theme-toggle';
  toggleButton.innerHTML = '<i class="fas fa-moon"></i>';
  document.body.appendChild(toggleButton);

  // Проверяем сохранённую тему
  if (localStorage.getItem('theme') === 'dark') {
    document.body.classList.add('dark-theme');
    toggleButton.innerHTML = '<i class="fas fa-sun"></i>';
  }

  // Переключение темы
  toggleButton.addEventListener('click', () => {
    document.body.classList.toggle('dark-theme');
    if (document.body.classList.contains('dark-theme')) {
      localStorage.setItem('theme', 'dark');
      toggleButton.innerHTML = '<i class="fas fa-sun"></i>';
    } else {
      localStorage.setItem('theme', 'light');
      toggleButton.innerHTML = '<i class="fas fa-moon"></i>';
    }
  });
});