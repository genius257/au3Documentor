#cs
# This is an example for annotating methods and properties on objects.
#
# This example demonstrates annotating COM objects, in this case a section of the COM from the Acrobat DC SDK
#ce

#cs
# @type AcroExchStatus -1|0 -1 if successful, 0 if not.
#ce

#cs
# @interface AcroExch.App The Acrobat application itself. This is a creatable interface. From the application layer, you can control the appearance of Acrobat, whether Acrobat appears, and the size of the application window. This object provides access to the menu bar and the toolbar, as well as the visual representation of a PDF file on the screen (through an AVDoc object).
#
# @method AcroExchStatus      CloseAllDocs()                                        Closes all open documents.
# @method AcroExchStatus      Exit()                                                Exits Acrobat.
# @method AcroExch.AVDoc      GetActiveDoc()                                        Gets the frontmost document.
# @method string              GetActiveTool()                                       Gets the name of the currently active tool.
# @method AcroExch.AVDoc|null GetAVDoc(long $nIndex)                                Gets an AcroExch.AVDoc object via its index within the list of open AVDoc objects.
# @method AcroExch.Rect       GetFrame()                                            Gets the window’s frame.
# @method IDispatch           GetInterface(string $szName)                          Gets an IDispatch interface for a named object, typically a third-party plug-in.
# @method string              GetLanguage()                                         Gets a code that specifies which language the Acrobat application’s user interface is using.
# @method long                GetNumAVDocs()                                        Gets the number of open AcroExch.AVDoc objects.
# @method long                GetPreference(short $nType)                           Gets a value from the preferences file.
# @method mixed               GetPreferenceEx(short $nType)                         Gets the specified application preference, using the VARIANT type to pass values.
# @method AcroExchStatus      Hide()                                                Hides the Acrobat application.
# @method AcroExchStatus      Lock(string $szLockedBy)                              Locks the Acrobat application.
# @method AcroExchStatus      Minimize(long $BMinimize)                             Minimizes the Acrobat application.
# @method AcroExchStatus      Maximize(long $bMaximize)                             Maximizes the Acrobat application.
# @method AcroExchStatus      MenuItemExecute(string $szMenuItemName)               Executes the menu item whose language-independent menu item name is specified.
# @method AcroExchStatus      MenuItemIsEnabled(string $szMenuItemName)             Determines whether the specified menu item is enabled.
# @method AcroExchStatus      MenuItemIsMarked(string $szMenuItemName)              Determines whether the specified menu item is marked.
# @method AcroExchStatus      MenuItemRemove(string $szMenuItemName)                Removes the menu item whose language-independent menu item is specified.
# @method AcroExchStatus      Restore(long $bRestore)                               Restores the main window of the Acrobat application.
# @method AcroExchStatus      SetActiveTool(string $szButtonName, long bPersistent) Sets the active tool according to the specified name, and determines whether the tool is to be used only once or should remain active after being used (persistent).
# @method AcroExchStatus      SetFrame(AcroExch.Rect $iAcroRect)                    Sets the window’s frame to the specified rectangle.
# @method AcroExchStatus      SetPreference(short $nType, long $nValue)             Sets a value in the preferences file.
# @method AcroExchStatus      SetPreferenceEx(short $nType, mixed $pVal)            Sets the application preference specified by nType to the value stored at pVal.
# @method AcroExchStatus      Show()                                                Shows the Acrobat application.
# @method AcroExchStatus      ToolButtonIsEnabled(string $szButtonName)             Determines whether the specified toolbar button is enabled.
# @method AcroExchStatus      ToolButtonRemove(string $szButtonName)                Removes the specified button from the toolbar.
# @method AcroExchStatus      Unlock()                                              Unlocks the Acrobat application if it was previously locked.
# @method AcroExchStatus      UnlockEx(string $szLockedBy)                          Unlocks the Acrobat application if it was previously locked.
#
# @see https://opensource.adobe.com/dc-acrobat-sdk-docs/acrobatsdk/html2015/index.html#t=Acro12_MasterBook%2FIAC_API_OLE_Objects%2FAcroExch_App.htm&rhsearch=CloseAllDocs&rhsyns=%20
#ce

#cs
# @enum long PDViewMode {
#   #cs
#   # leave the view mode as it is
#   #ce
#   PDDontCare: 0,
#   #cs
#   # display without bookmarks or thumbnails
#   #ce
#   PDUseNone: 1,
#   #cs
#   # display using thumbnails
#   #ce
#   PDUseThumbs: 2,
#   #cs
#   # display using bookmarks
#   #ce
#   PDUseBookmarks: 3,
#   #cs
#   # display in full screen mode
#   #ce
#   PDFullScreen: 4,
# }
#ce

#cs
# @enum long AV_VIEW {
#   #cs
#   # Display the AVPageView, scrollbars, toolbar, and bookmark or thumbnails pane. Annotations are active.
#   #ce
#   EXTERNAL,
#   #cs
#   # Display the AVPageView, scrollbars, and bookmark or thumbnails pane. Annotations are active.
#   #ce
#   DOC,
#   #cs
#   # Display only the AVPageView (the window that displays the PDF file). Do not display scrollbars, the toolbar, and bookmark or thumbnails pane. Annotations are active.
#   #ce
#   PAGE,
# }
#ce

#cs
# @enum short AV_PAGE_VIEW_MODE {
#   #cs
#   # leave the view mode as it is
#   #ce
#   DontCare: 0,
#   #cs
#   # display without bookmarks or thumbnails
#   #ce
#   PDUseNone: 1,
#   #cs
#   # display using thumbnails
#   #ce
#   PDUseThumbs: 2,
#   #cs
#   # display using bookmarks
#   #ce
#   PDUseBookmarks: 3,
#   #cs
#   # display in full screen mode
#   #ce
#   PDFullScreen: 4,
# }
#ce

#cs
# @enum short AVZoom {
#   #cs
#   # Fits the page’s height in the window.
#   #ce
#   FitHeight,
#   #cs
#   # Fits the page in the window.
#   #ce
#   FitPage,
#   #cs
#   # Fits the page’s visible content into the window.
#   #ce
#   FitVisibleWidth,
#   #cs
#   # Fits the page’s width into the window.
#   #ce
#   FitWidth,
#   #cs
#   # A fixed zoom, such as 100%.
#   #ce
#   NoVary,
# }
#ce

#cs
# @interface AcroExch.AVDoc A view of a PDF document in a window. This is a creatable interface. There is one AVDoc object per displayed document. Unlike a PDDoc object, an AVDoc object has a window associated with it.
#
# @method AcroExchStatus            BringToFront()                                                                                                                                                                            Brings the window to the front.
# @method AcroExchStatus            ClearSelection()                                                                                                                                                                          Clears the current selection.
# @method -1                        Close(long $bNoSave)                                                                                                                                                                      Closes a document.
# @method AcroExchStatus            FindText(string $szText, long $bCaseSensitive, long $bWholeWordsOnly, long $bReset)                                                                                                       Finds the specified text, scrolls so that it is visible, and highlights it.
# @method AcroExch.AVPageView|null  GetAVPageView()                                                                                                                                                                           Gets the AcroExch.AVPageView associated with an AcroExch.AVDoc.
# @method AcroExch.Rect|null        GetFrame()                                                                                                                                                                                Gets the rectangle specifying the window’s size and location.
# @method AcroExch.PDDoc|null       GetPDDoc()                                                                                                                                                                                Gets the AcroExch.PDDoc associated with an AcroExch.AVDoc.
# @method string|null               GetTitle()                                                                                                                                                                                Gets the window’s title.
# @method PDViewMode                GetViewMode()                                                                                                                                                                             Gets the current document view mode (pages only, pages and thumbnails, or pages and bookmarks).
# @method AcroExchStatus            IsValid()                                                                                                                                                                                 Determines whether the AcroExch.AVDoc is still valid.
# @method AcroExchStatus            Maximize(long $bMaxSize)                                                                                                                                                                  Maximizes the window if bMaxSize is a positive number.
# @method AcroExchStatus            Open(string $szFullPath, string $szTempTitle?)                                                                                                                                            Opens a file.
# @method -1                        OpenInWindow(string $fileName, short $hWnd)                                                                                                                                               Opens a PDF file and displays it in a user-specified window.
# @method AcroExchStatus            OpenInWindowEx(string $szFullPath, long $hWnd, AV_VIEW $openFlags, long $useOpenParams, long $pgNum, AV_PAGE_VIEW_MODE $pageMode, AVZoom $zoomType, long $zoom, short $top, short $left)  Opens a PDF file and displays it in a user-specified window.
# @method AcroExchStatus            PrintPages(long $nFirstPage, long $nLastPage, 2|3 $nPSLevel, long $bBinaryOk, long $bShrinkToFit)                                                                                         Prints a specified range of pages displaying a print progress dialog box.
# @method AcroExchStatus            printPagesEx(long $nFirstPage, long $nLastPage, 2|3 $nPSLevel, long $bBinaryOk, long $bShrinkToFit, long $bReverse, long $bFarEastFontOpt, long $bEmitHalftones, long $iPageOption)       Prints a specified range of pages, displaying a print progress dialog box.
# @method AcroExchStatus            PrintPagesSilent(long $nFirstPage, long $nLastPage, 2|3 nPSLevel, long $bBinaryOk, long $bShrinkToFit)                                                                                    Prints a specified range of pages without displaying any dialog box.
# @method AcroExchStatus            PrintPagesSilentEx(long $nFirstPage, long $nLastPage, 2|3 $nPSLevel, long $bBinaryOk, long $bShrinkToFit, long $bReverse, long $bFarEastFontOpt, long $bEmitHalftones, long $iPageOption) Prints a specified range of pages without displaying any dialog box.
# @method -1                        SetFrame(AcroExch.Rect $iAcroRect)                                                                                                                                                        Sets the window’s size and location.
# @method AcroExchStatus            SetTextSelection(AcroExch.PDTextSelect $iAcroPDTextSelect)                                                                                                                                Sets the document’s selection to the specified text selection.
# @method AcroExchStatus            SetTitle(string $szTitle)                                                                                                                                                                 Sets the window’s title.
# @method AcroExchStatus            SetViewMode(PDViewMode $nType)                                                                                                                                                            Sets the mode in which the document will be viewed (pages only, pages and thumbnails, or pages and bookmarks).
# @method AcroExchStatus            ShowTextSelect()                                                                                                                                                                          Changes the view so that the current text selection is visible.
#ce

#cs
# @enum long PDViewMode { //FIXME: already defined above, see usage above to verify if a subset is required.
#   DontCare: 0,
#   UseNone: 1,
#   UseThumbs: 2,
#   UseBookmarks: 3,
# }
#ce

#cs
# @interface AcroExch.PDDoc
#
# @method AcroExch.PDPage       AcquirePage(long $nPage) Acquires the specified page.
# @method AcroExchStatus        ClearFlags(long $nFlags) Clears a document’s flags.
# @method AcroExchStatus        Close()                  Closes a file.
# @method AcroExchStatus        Create()                 Creates a new AcroExch.PDDoc.
# @method AcroExch.PDTextSelect CreateTextSelect(long $nPage, AcroExch.Rect $iAcroRect) Creates a text selection from the specified rectangle on the specified page.
# @method AcroExchStatus        CreateThumbs(long $nFirstPage, long $nLastPage)
# @method AcroExchStatus        CropPages(long $nStartPage, long $nEndPage, short $nEvenOrOddPagesOnly, AcroExch.Rect $iAcroRect) Crops the pages in a specified range in a document.
# @method AcroExchStatus        DeletePages(long $nStartPage, long $nEndPage) Deletes pages from a file.
# @method AcroExchStatus        DeleteThumbs(long $nStartPage, long $nEndPage) Deletes thumbnail images from the specified pages in a document.
# @method string                GetFileName() Gets the name of the file associated with this AcroExch.PDDoc.
# @method long                  GetFlags() Gets a document’s flags.
# @method string                GetInfo(string $szInfoKey) Gets the value of a specified key in the document’s Info dictionary.
# @method string                GetInstanceID() Gets the instance ID (the second element) from the ID array in the document’s trailer.
# @method Dispatch              GetJSObject()   Gets a dual interface to the JavaScript object associated with the PDDoc.
# @method long                  GetNumPages()   Gets the number of pages in a file.
# @method PDViewMode            GetPageMode()   Gets a value indicating whether the Acrobat application is currently displaying only pages, pages and thumbnails, or pages and bookmarks.
# @method string                GetPermanentID() Gets the permanent ID (the first element) from the ID array in the document’s trailer.
# @method AcroExchStatus        InsertPages(long $nInsertPageAfter, AcroExch.PDDoc $iPDDocSource, long $nStartPage, long $nNumPages, long $bBookmarks) Inserts the specified pages from the source document after the indicated page within the current document.
# @method AcroExchStatus        MovePage(long $nMoveAfterThisPage, long $nPageToMove) Moves a page to another location within the same document.
# @method AcroExchStatus        Open(string $fileName) Opens a file.
# @method AcroExch.AVDoc        OpenAVDoc(string $szTitle) Opens a window and displays the document in it.
# @method AcroExchStatus        ReplacePages(long $nStartPage, AcroExch.PDDoc $iPDDocSource, long $nStartSourcePage, long $nNumPages, long $bMergeTextAnnotations) Replaces the indicated pages in the current document with those specified from the source document.
# @method AcroExchStatus        Save(short $nType, string $szFullPath) Saves a document.
# @method -1                    SetFlags(long $nFlags) Sets a document’s flags indicating whether the document has been modified, whether the document is a temporary document and should be deleted when closed, and the version of PDF used in the file.
# @method AcroExchStatus        SetInfo(string $szInfoKey, string $szBuffer) Sets the value of a key in a document’s Info dictionary.
# @method AcroExchStatus        SetPageMode(PDViewMode $nPageMode) Sets the page mode in which a document is to be opened: display only pages, pages and thumbnails, or pages and bookmarks.
#ce

#cs
# Defines the location of an AcroRect.
#
# @interface AcroExch.Rect
#
# @property short Bottom Gets or sets the bottom y-coordinate of an AcroRect.
# @property short Left   Gets or sets left x-coordinate of an AcroRect.
# @property short Right  Gets or sets the right x-coordinate of an AcroRect.
# @property short Top    Gets or sets the top y-coordinate of an AcroRect.
#ce

#cs
# @var AcroExch.App
#ce
$oApp = ObjGet("", "AcroExch.App")
$oAVDoc = $oApp.GetActiveDoc()
if $oAVDoc = null then Exit MsgBox(0, "null value encountered", "GetActiveDoc result is null.")
$oPDDoc = $oAVDoc.GetPDDoc()
if $oPDDoc = null then Exit MsgBox(0, "null value encountered", "GetPDDoc result is null.")
MsgBox(0, "GetNumPages", $oPDDoc.GetNumPages())
