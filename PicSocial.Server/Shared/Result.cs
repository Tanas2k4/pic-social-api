namespace PicSocial.Server.Shared
{
    public class Result
    {
        public bool Success { get; set; }
        public string Message { get; set; } = "";
        public int StatusCode { get; set; }

        // Constructor
        public Result(bool success = true, string message = "", int statusCode = 200)
        {
            Success = success;
            Message = message;
            StatusCode = statusCode;
        }

        public static Result Ok(string message = "") => new Result(true, message, 200);
        public static Result NotFound(string message = "") => new Result(false, message, 404);
        public static Result Bad(string message = "") => new Result(false, message, 400);
        public static Result Forbidden(string message = "") => new Result(false, message, 403);
        public static Result Unauthorized(string message = "") => new Result(false, message, 401);
    }

    // Generic version of Result to hold data
    //public class Result<T> : Result
    //{
    //    public T? Data { get; set; }

    //    public Result(bool success = true, string message = "", int statusCode = 200, T? data = default)
    //        : base(success, message, statusCode)
    //    {
    //        Data = data;
    //    }

    //    public static Result<T> Ok(T data, string message = "") => new Result<T>(true, message, 200, data);
    //    public static Result<T> NotFound(string message = "") => new Result<T>(false, message, 404);
    //    public static Result<T> Bad(string message = "") => new Result<T>(false, message, 400);
    //    public static Result<T> Forbidden(string message = "") => new Result<T>(false, message, 403);
    //    public static Result<T> Unauthorized(string message = "") => new Result<T>(false, message, 401);
    //}
}
