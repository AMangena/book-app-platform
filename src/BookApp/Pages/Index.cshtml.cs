using BookApp.Models;
using BookApp.Services;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace BookApp.Pages;

public class IndexModel : PageModel
{
    private readonly IBookService _bookService;
    public IndexModel(IBookService bookService) => _bookService = bookService;
    public IReadOnlyList<Book> Books { get; private set; } = Array.Empty<Book>();
    public void OnGet() => Books = _bookService.GetAllBooks();
}
