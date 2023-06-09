# Postman_Project
Изначально, данный проект задумывался как использование инструмента Interceptor.
Написание и тестирование запросов планировала делать по другому swagger.
Но пошаговая модернизация проекта привела к его полному изменению и очень затянула.
В запросы добавлены переменные для минимизации ручных корректировок при изменении данных.
Для проверки ключевых моментов каждого запроса добавлены pre-request scripts и/или tests.

Ссылка на сайт, который использовался в проекте, и swagger:
https://demoqa.com/login
https://demoqa.com/swagger/#/

Проект начинается с создания нового пользователя, который проходит процесс регистрации и заходит в свой аккаунт.
Пользователь может посмотреть все книги в магазине, добавить их в свой аккаунт, удалить все книги из аккаунта или удалить аккаунт.

В итоге реализовано 2 версии с небольшими изменениями.
Можно смотреть только v2, так как она полноценная, но v1 тоже решила оставить.
v1 - можно запускать в collection runner и newman, при ручном запуске добавляется только первая книга и падает 2 теста (в этом и следующем запросе).
v2 - можно запускать в collection runner, newman и вручную. При ручном запуске добавление книг будет последовательно по одной.
После добавления всех книг и попытке добавить еще книги будет сообщение в консоли, что все книги добавлены и упадет 1 тест.

Проект по шагам:
* Первый запрос на создание нового пользователя - POST (Create new user).
В теле запроса передаем имя пользователя и пароль (через переменные).
После разных вариантов с входными данными, решила остановиться на разовом заведении в переменные окружения (в initial value) рандомных данных для имени пользователя и пароля.
Это сильно упрощает запуск экспортированной коллекции в newman, так как не требуется корректировать файл окружения вручную или сохранять переменные в initial перед экспортом.

В tests проверяем статус код 201 (Created) и наличие имени пользователя в response, а также парсим запрос для получения сгенерированного имени и пароля и записываем в переменные.
Это позволит использовать во всех остальных запросах именно данные, сгенерированные в первом запросе.

* Второй, третий и четвертый запросы похожи, они все POST (GenerateToken, Auth, Login), в каждом одинаковое тело запроса.
Также передаем имя пользователя и пароль через переменные, добавляем тесты на статус код 200 (OK).
В запросе на генерацию токена добавлен тест на получение строки с токеном в response.
В запросе на авторизацию добавлен тест на получение true в response.
В запросе на логирование добавлены тесты на получение строки с токеном и идентификационным номером пользователя, которые добавляем в переменные окружения.
Эти переменные будут необходимы для дальнейших запросов.

* В запросе (GET) Get user получаем информацию о пользователе.
Добавляем переменную с токеном для авторизации и в путь запроса переменную с userId. 
В pre-request scripts информационно выводим данные о наличии и значениях идентификационного номера пользователя и токена.
В тестах проверяем статус код 200 (OK) и отсутствие книг у пользователя в аккаунте.

* В запросе (GET) Get books получаем информацию о доступных в магазине книгах.
Здесь не требуется userId и токен.
В тестах устанавливаем в переменную коллекции информацию о количестве доступных книг, а также проверяем, что их количество больше 0.
Стандартно проверяем статус код 200 (OK).
Выделяем идентификаторы книг в отдельный массив, который будет использоваться в следующем запросе через переменную коллекции (для версии 2) и локальную переменную (в версии 1).

* Следующим запросом (POST) Add all books to the user (loop) добавляем книги пользователю.
В исходных версиях проекта добавление книг было по идентификатору, но добавление всех книг последовательным циклом интереснее и сложнее.
Именно на этом запросе идет ключевое разделение 1 и 2 версии.
В этом запросе также требуется добавить переменную с токеном для авторизации.
В теле запроса используются переменные userId и текущий идентификатор книги.
В tests проверяем статус код 201 (Created).
В pre-request scripts назначается текущий идентификатор книги, который сдвигается на единицу при каждом новом цикле.
При ручном запуске добавление всех книг возможно только в v2.

* В запросе (GET) Get user after Add books получаем информацию о пользователе после добавления книг.
Добавляем переменную с токеном для авторизации и в путь запроса переменную с userId. 
В тестах проверяем статус код 200 (OK) и соответствие ожидаемого количества книг с фактически добавленными.

* В запросе (DELETE) Delete all books удаляем все книги у пользователя.
Добавляем переменную с токеном для авторизации и переменную с userId в query params. 
В тестах проверяем статус код 204 (No Content), что соответствует success.

* В запросе (GET) Get user after Delete books получаем информацию о пользователе после удаления всех книг.
Добавляем переменную с токеном для авторизации и в путь запроса переменную с userId. 
В тестах проверяем статус код 200 (OK) и отсутствие книг у пользователя в аккаунте.

* В запросе (DELETE) Delete user удаляем пользователя.
Добавляем переменную с токеном для авторизации и переменную с userId в путь. 
В тестах проверяем статус код 204 (No Content), это не соответствует swagger, но фактически соответствует success.

* В запросе (GET) Get user after Delete получаем информацию о пользователе после удаления.
Добавляем переменную с токеном для авторизации и в путь запроса переменную с userId. 
В тестах проверяем статус код 401 (Unauthorized) и удаляем переменные окружения, которые были созданы при выполнении коллекции.
Остаются 2 исходные рандомные переменные.
