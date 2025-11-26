namespace PicSocial.Server.Shared
{
    public class Results<T> : Result
    {
        public T? Data { get; set; }

        public Results(bool success = true, string message = "", int statusCode = 200, T? data = default)
            : base(success, message, statusCode)
        {
            Data = data;
        }

        public static Results<T> Ok(T data, string message = "") => new Results<T>(true, message, 200, data);
        public static Results<T> NotFound(string message = "") => new Results<T>(false, message, 404);
        public static Results<T> Bad(string message = "") => new Results<T>(false, message, 400);
        public static Results<T> Forbidden(string message = "") => new Results<T>(false, message, 403);
        public static Results<T> Unauthorized(string message = "") => new Results<T>(false, message, 401);
    }
}
