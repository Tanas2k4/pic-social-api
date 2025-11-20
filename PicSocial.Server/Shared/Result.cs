namespace PicSocial.Server.Shared
{
    public class Result
    {
        public bool Success { get; set; }
        public string Message { get; set; } = "";

        public Result() { }
        public Result(bool success, string message)
        {
            Success = success;
            Message = message;
        }

        public static Result Fail(string message) => new Result(false, message);
        public static Result Ok(string message = "") => new Result(true, message);
    }
}
