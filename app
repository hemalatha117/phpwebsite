[6:12 pm, 18/06/2020] Kavya Idea No: <?php
namespace App\Http\Controllers;

use App\User;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;

class UserController extends Controller
{
    public function postSignUp(Request $request)
    {
        $this->validate($request, [
            'email' => 'required|email|unique:users',
            'first_name' => 'required|max:120',
            'password' => 'required|min:4'
        ]);

        $email = $request['email'];
        $first_name = $request['first_name'];
        $password = bcrypt($request['password']);

        $user = new User();
        $user->email = $email;
        $user->first_name = $first_name;
        $user->password = $password;

        $user->save();

        Auth::login($user);

        return redirect()->route('dashboard');
    }

    public function postSignIn(Request $request)
    {
        $this->validate($request, [
            'email' => 'required',
            'password' => 'required'
        ]);

        if (Auth::attempt(['email' => $request['email'], 'password' => $request['password']])) {
            return redirect()->route('dashboard');
        }
        return redirect()->back();
    }

    public function getLogout()
    {
        Auth::logout();
        return redirect()->route('home');
    }

    public function getAccount()
    {
        return view('account', ['user' => Auth::user()]);
    }

    public function postSaveAccount(Request $request)
    {
        $this->validate($request, [
           'first_name' => 'required|max:120'
        ]);

        $user = Auth::user();
        $old_name = $user->first_name;
        $user->first_name = $request['first_name'];
        $user->update();
        $file = $request->file('image');
        $filename = $request['first_name'] . '-' . $user->id . '.jpg';
        $old_filename = $old_name . '-' . $user->id . '.jpg';
        $update = false;
        if (Storage::disk('local')->has($old_filename)) {
            $old_file = Storage::disk('local')->get($old_filename);
            Storage::disk('local')->put($filename, $old_file);
            $update = true;
        }
        if ($file) {
            Storage::disk('local')->put($filename, File::get($file));
        }
        if ($update && $old_filename !== $filename) {
            Storage::delete($old_filename);
        }
        return redirect()->route('account');
    }

    public function getUserImage($filename)
    {
        $file = Storage::disk('local')->get($filename);
        return new Response($file, 200);
    }
}

        ]);

        $user = Auth::user();
        $old_name = $user->first_name;
        $user->first_name = $request['first_name'];
        $user->update();
        $file = $request->file('image');
        $filename = $request['first_name'] . '-' . $user->id . '.jpg';
        $old_filename = $old_name . '-' . $user->id . '.jpg';
        $update = false;
        if (Storage::disk('local')->has($old_filename)) {
            $old_file = Storage::disk('local')->get($old_filename);
            Storage::disk('local')->put($filename, $old_file);
            $update = true;
        }
        if ($file) {
            Storage::disk('local')->put($filename, File::get($file));
        }
        if ($update && $old_filename !== $filename) {
            Storage::delete($old_filename);
        }
        return redirect()->route('account');
    }

126 app/Http/routes.php



Route::group(['middleware' => ['web']], function () {
    Route::get('/', function () {
        return view('welcome');
    })->name('home');

    Route::post('/signup', [
        'uses' => 'UserController@postSignUp',
        'as' => 'signup'
    ]);

    Route::post('/signin', [
        'uses' => 'UserController@postSignIn',
        'as' => 'signin'
    ]);

    Route::get('/logout', [
        'uses' => 'UserController@getLogout',
        'as' => 'logout'
    ]);

    Route::get('/account', [
        'uses' => 'UserController@getAccount',
        'as' => 'account'
    ]);

    Route::post('/upateaccount', [
        'uses' => 'UserController@postSaveAccount',
        'as' => 'account.save'
    ]);

    Route::get('/userimage/{filename}', [
        'uses' => 'UserController@getUserImage',
        'as' => 'account.image'
    ]);

    Route::get('/dashboard', [
        'uses' => 'PostController@getDashboard',
        'as' => 'dashboard',
        'middleware' => 'auth'
    ]);

    Route::post('/createpost', [
        'uses' => 'PostController@postCreatePost',
        'as' => 'post.create',
        'middleware' => 'auth'
    ]);

    Route::get('/delete-post/{post_id}', [
        'uses' => 'PostController@getDeletePost',
        'as' => 'post.delete',
        'middleware' => 'auth'
    ]);

    Route::post('/edit', [
        'uses' => 'PostController@postEditPost',
        'as' => 'edit'
    ]);

    Route::post('/like', [
       'uses' => 'PostController@postLikePost',
        'as' => 'like'
    ]);
});

Route::get('/', function () {
    return view('welcome');
})->name('home');

Route::post('/signup', [
    'uses' => 'UserController@postSignUp',
    'as' => 'signup'
]);

Route::post('/signin', [
    'uses' => 'UserController@postSignIn',
    'as' => 'signin'
]);

Route::get('/logout', [
    'uses' => 'UserController@getLogout',
    'as' => 'logout'
]);

Route::get('/account', [
    'uses' => 'UserController@getAccount',
    'as' => 'account'
]);

Route::post('/upateaccount', [
    'uses' => 'UserController@postSaveAccount',
    'as' => 'account.save'
]);

Route::get('/userimage/{filename}', [
    'uses' => 'UserController@getUserImage',
    'as' => 'account.image'
]);

Route::get('/dashboard', [
    'uses' => 'PostController@getDashboard',
    'as' => 'dashboard',
    'middleware' => 'auth'
]);

Route::post('/createpost', [
    'uses' => 'PostController@postCreatePost',
    'as' => 'post.create',
    'middleware' => 'auth'
]);

Route::get('/delete-post/{post_id}', [
    'uses' => 'PostController@getDeletePost',
    'as' => 'post.delete',
    'middleware' => 'auth'
]);

Route::post('/edit', [
    'uses' => 'PostController@postEditPost',
    'as' => 'edit'
]);

Route::post('/like', [
    'uses' => 'PostController@postLikePost',
    'as' => 'like'
]);

4 app/Providers/RouteServiceProvider.php
@@ -37,7 +37,9 @@ public function boot(Router $router)
     */
    public function map(Router $router)
    {
        $router->group(['namespace' => $this->namespace], function ($router) {
        $router->group([
            'namespace' => $this->namespace, 'middleware' => 'web',
        ], function ($router) {
            require app_path('Http/routes.php');
        });
    }


