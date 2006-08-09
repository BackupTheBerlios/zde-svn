/* XXX What is really fucking stupid is that Doxygen only takes function decls in C++ format for Objective C.  Isn't that retarded? */

/** \class ObjXCBDrawable
 * \brief Represents an object that can be drawn to.
 *
 */

/** \class ObjXCBPixmap
 * \brief An object that represents drawable pixel data.
 *
 */

/** \class ObjXCBWindow
 *  \brief An object that represents visible drawable pixel data.
 *
 */

/** \class ObjXCBAtom
 * \brief A structure used to store various properties attatched to windows.
 * To create an atom, it must be "interned" first.  The InternAtom method is in ObjXCBConnection (Orphan).
 */

/** \class ObjXCBColormap
 * \brief Describes the available colors that can be used.
 */

/** \class ObjXCBCursor
 * \brief A cursor 
 */

/** \class ObjXCBFont
 * \brief A core X font.  These are depricated, you should use something like Xft or Pango if you want smooth anti-aliased fonts and UTF8 support.
 */

/** \class ObjXCBFontable
 * \brief Structure for using core fonts.
 */

/** \class ObjXCBGcontext
 * \brief A context for drawing onto ObjXCBDrawables.
 */


/* Sections, these explain parts of Obj-XCB that don't belong anywhere else. */

/**
 * \addtogroup Replies
 * @{
 * 
 * Reply object are returned by Obj-XCB methods that need to return multiple values.  The interesting thing about XCB is that replies are not actually
 * retrieved when you call a function that returns, you are instead given an ID for the reply.  You then must call a special funtion that forces the reply,
 * and gives you a structure containing values.  This allows you to queue up a string of functions that all return values, but only initiate the actual
 * request when you need the values.  This allows you to strategically place queueing the request and actually calling the request in your code, in order to
 * hide latency.  Obj-XCB takes advantage of this feature also, through the reply objects.  Whenever you call a request that in XCB would normally give you an
 * ID for the request value, you are given the actual object that you use to access the values.  But, when you actually use the methods on the object to get at 
 * the data, that is then when the reply is forced, not before.  Therefore, you can have the same power that is available in plain XCB without keeping track of 
 * hundreds of different variables, instead it is all neatly encapsulated into a black box object that does the work for you.
 *
 * Each reply object has accessor methods that correspond to the XCB structure memebers.  Each reply should also be freed when you are done with it, and never
 * allocated or created yourself.
 *
 */

