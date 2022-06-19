<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/



Auth::routes([
    'register' => false,
    'reset'    => false,
    'verify' => false
]);

Route::get('/home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
//Route::get('quiz/{quizId}', [App\Http\Controllers\ExamController::class, 'getQuizQuestions'])->middleware('auth');

Route::get('user/quiz/{quizId}',[App\Http\Controllers\ExamController::class, 'getQuizQuestions'])->middleware('auth');
Route::post('quiz/create', [App\Http\Controllers\ExamController::class, 'postQuiz'])->middleware('auth');
Route::get('/result/user/{userId}/quiz/{quizId}', [App\Http\Controllers\ExamController::class, 'viewResult'])->middleware('auth');

Route::group(['middleware' => 'isAdmin'], function(){
    Route::get('/', function () {
        return view('admin.index');
    });

    Route::resource('quiz', App\Http\Controllers\QuizController::class);
    Route::resource('question', App\Http\Controllers\QuestionController::class);
    Route::resource('user', App\Http\Controllers\UserController::class);
    Route::get('/quiz/{id}/questions', [App\Http\Controllers\QuizController::class, 'question'])->name('quiz.question');
});






	Route::get('exam/assign',[App\Http\Controllers\ExamController::class, 'create'])->name('user.exam');
	Route::post('exam/assign',[App\Http\Controllers\ExamController::class, 'assignExam'])->name('exam.assign');
  	Route::get('exam/user',[App\Http\Controllers\ExamController::class, 'userExam'])->name('view.exam');
	Route::post('exam/remove',[App\Http\Controllers\ExamController::class, 'removeExam'])->name('exam.remove');
    Route::get('result',[App\Http\Controllers\ExamController::class, 'result'])->name('result');
    Route::get('result/{userId}/{quizId}', [App\Http\Controllers\ExamController::class, 'userQuizResult']);
