using Microsoft.AspNetCore.Mvc;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PingController : ControllerBase
    {      
        [HttpGet]
        public IActionResult GetALl() => Ok (new { message = "pong" });   //Sử dụng để test API + hiển thị      
    }
}


