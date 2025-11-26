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
}
