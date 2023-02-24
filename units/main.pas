unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons, StdCtrls,
  ExtCtrls, ComCtrls, Types, LCLType;

type

  { Tfrmmain }

  Tfrmmain = class(TForm)
    chkMatchcase: TCheckBox;
    chkLineNum: TCheckBox;
    cmdAddFolder: TSpeedButton;
    cmdClearList: TSpeedButton;
    cmdCopy: TSpeedButton;
    cmdSaveList: TSpeedButton;
    cmdRemoveFile: TSpeedButton;
    cmdOpenList: TSpeedButton;
    cmdSaveLine: TSpeedButton;
    cmdAbout: TSpeedButton;
    cmdExit: TSpeedButton;
    cmdSearch: TButton;
    cmdAddFile: TSpeedButton;
    fraOptions: TGroupBox;
    ImgIcons: TImageList;
    lblFindFile: TLabeledEdit;
    lblFoundLines: TLabel;
    lblFind: TLabeledEdit;
    lstFiles: TListBox;
    txtLines: TMemo;
    R1: TRadioButton;
    R2: TRadioButton;
    StatusBar1: TStatusBar;
    procedure cmdAboutClick(Sender: TObject);
    procedure cmdAddFileClick(Sender: TObject);
    procedure cmdAddFolderClick(Sender: TObject);
    procedure cmdClearListClick(Sender: TObject);
    procedure cmdCopyClick(Sender: TObject);
    procedure cmdExitClick(Sender: TObject);
    procedure cmdOpenListClick(Sender: TObject);
    procedure cmdRemoveFileClick(Sender: TObject);
    procedure cmdSaveLineClick(Sender: TObject);
    procedure cmdSaveListClick(Sender: TObject);
    procedure cmdSearchClick(Sender: TObject);
    procedure lblFindChange(Sender: TObject);
    procedure lblFindFileChange(Sender: TObject);
    procedure lblFindKeyPress(Sender: TObject; var Key: char);
    procedure lstFilesClick(Sender: TObject);
    procedure lstFilesDrawItem(Control: TWinControl; Index: integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure lstFilesMeasureItem(Control: TWinControl; Index: integer;
      var AHeight: integer);
  private
    procedure GetFiles;
    procedure AddFolder;
    procedure OpenList;
    procedure SaveList;
    procedure FindInFile(Filename, sFind: string);
    function IsStringInList(lb: TListBox; sFind: string): boolean;
    function FixPath(S: string): string;
    function ExtractFileTitle(S: string): string;
    procedure FindFileInList(lb: TListBox; sFind: string);
  public

  end;

const
  def_ext = 'Text Files(*.txt)|*.txt|All Files(*.*)|*.*';

var
  frmmain: Tfrmmain;

implementation

{$R *.lfm}

{ Tfrmmain }

function Tfrmmain.ExtractFileTitle(S: string): string;
var
  sPos: integer;
begin
  sPos := Pos('.', S);
  if sPos > 0 then
  begin
    Result := LeftStr(S, sPos - 1);
  end
  else
  begin
    Result := S;
  end;
end;

procedure Tfrmmain.FindFileInList(lb: TListBox; sFind: string);
var
  X, idx, sPos: integer;
  lzFileTitle: string;
begin
  idx := -1;
  lzFileTitle := '';
  lstFiles.ItemIndex := -1;
  for X := 0 to lb.Count - 1 do
  begin
    lzFileTitle := LowerCase(ExtractFileTitle(ExtractFileName(lb.Items[X])));
    //Locate the the string in the list
    sPos := Pos(lowercase(sFind), lzFileTitle);
    if sPos > 0 then
    begin
      idx := X;
      Break;
    end;
  end;

  if idx <> -1 then
  begin
    lb.ItemIndex := idx;
    lb.Selected[idx] := True;
    lstFilesClick(nil);
  end;
end;

function Tfrmmain.FixPath(S: string): string;
begin
  if rightstr(S, 1) <> PathDelim then
  begin
    Result := S + PathDelim;
  end
  else
  begin
    Result := S;
  end;
end;

procedure Tfrmmain.FindInFile(Filename, sFind: string);
var
  lst, Temp: TStringList;
  sPos, X: integer;
  sLine, sTemp, ToFind: string;
begin
  if FileExists(Filename) then
  begin
    lst := TStringList.Create;
    Temp := TStringList.Create;
    lst.LoadFromFile(Filename);
    //Clear the memo
    txtLines.Lines.Clear;
    //Loop tho the file contents line by line
    //Set to find text
    ToFind := sFind;
    for X := 0 to lst.Count - 1 do
    begin
      sLine := lst[X];
      sTemp := sLine;
      //If not matching text case
      if not chkMatchcase.Checked then
      begin
        sLine := lowercase(lst[X]);
        ToFind := lowercase(sFind);
      end;

      if Length(sLine) <> 0 then
      begin
        //Find the sub string in sLine

        sPos := Pos(ToFind, sLine);

        if R1.Checked then
        begin
          if sPos <> 0 then
          begin
            if chkLineNum.Checked then
            begin
              Temp.Add(IntToStr(X) + ':' + #9 + sTemp);
            end
            else
            begin
              Temp.Add(sTemp);
            end;
          end;
        end;

        if R2.Checked then
        begin
          if sPos = 0 then
          begin
            if chkLineNum.Checked then
            begin
              Temp.Add(IntToStr(X) + ':' + #9 + sTemp);
            end
            else
            begin
              Temp.Add(sTemp);
            end;
          end;
        end;
      end;
    end;

    txtLines.Lines.Assign(Temp);
    //Clear up time.
    FreeAndNil(lst);
    FreeAndNil(Temp);
  end;
end;

function Tfrmmain.IsStringInList(lb: TListBox; sFind: string): boolean;
var
  I: integer;
  found: boolean;
begin
  found := False;
  for I := 0 to lb.Items.Count - 1 do
  begin
    if lowercase(lb.Items[I]) = lowercase(sFind) then
    begin
      found := True;
      Break;
    end;
  end;
  Result := found;
end;

procedure Tfrmmain.AddFolder;
var
  bf: TSelectDirectoryDialog;
  sr: TSearchRec;
  lzFolder, lzFile: string;
begin
  bf := TSelectDirectoryDialog.Create(self);
  bf.Title := 'Select Folder';
  if bf.Execute then
  begin
    //Get folder location
    lzFolder := FixPath(bf.FileName);

    if FindFirst(lzFolder + '*.txt', faAnyFile, sr) = 0 then
    begin
      repeat
        lzFile := lzFolder + sr.Name;
        //Check if file is in listbox
        if not IsStringInList(lstFiles, lzFile) then
        begin
          //Add file
          lstFiles.Items.Add(lzFile);
        end;

      until FindNext(sr) <> 0;
    end;
  end;

  FreeAndNil(bf);
end;

procedure Tfrmmain.GetFiles;
var
  od: TOpenDialog;
  X: integer;
begin
  od := TOpenDialog.Create(self);
  od.Title := 'Select Files';
  od.Filter := def_ext;
  od.Options := [ofAllowMultiSelect];

  if od.Execute then
  begin
    for X := 0 to od.Files.Count - 1 do
    begin
      if not IsStringInList(lstFiles, od.Files[X]) then
      begin
        lstFiles.Items.Add(od.Files[X]);
      end;
    end;
  end;

  FreeAndNil(od);

end;

procedure Tfrmmain.OpenList;
var
  od: TOpenDialog;
  sl: TStringList;
  X: integer;
begin

  sl := TStringList.Create;
  od := TOpenDialog.Create(self);
  od.Title := 'Open';
  od.Filter := 'List Files(*.lst)|*.lst';
  if od.Execute then
  begin
    //Load file into list
    sl.LoadFromFile(od.FileName);
    for X := 0 to sl.Count - 1 do
    begin
      if not IsStringInList(lstFiles, sl[X]) then
      begin
        lstFiles.Items.Add(sl[X]);
      end;
    end;
  end;

  FreeAndNil(sl);
  FreeAndNil(od);
end;

procedure Tfrmmain.SaveList;
var
  sd: TSaveDialog;
begin
  sd := TSaveDialog.Create(self);
  sd.Title := 'Save';
  sd.Filter := 'List Files(*.lst)|*.lst';
  sd.DefaultExt := 'lst';

  if sd.Execute then
  begin
    if FileExists(sd.FileName) then
    begin
      if MessageDlg(Text, 'The filename:' + sLineBreak + sLineBreak +
        sd.FileName + ' Already exists.' + sLineBreak + sLineBreak +
        'Are you sure you want to continue.', mtConfirmation, [mbYes, mbNo], 0) =
        mrYes then
      begin
        //Save list
        lstFiles.Items.SaveToFile(sd.FileName);
      end;
    end
    else
    begin
      //Save list
      lstFiles.Items.SaveToFile(sd.FileName);
    end;
  end;

  FreeAndNil(sd);
end;

procedure Tfrmmain.cmdAddFileClick(Sender: TObject);
begin
  GetFiles;
end;

procedure Tfrmmain.cmdAboutClick(Sender: TObject);
begin
  MessageDlg('About', Text + sLineBreak + 'Version 1.0' + sLineBreak +
    sLineBreak + #9 + 'Simple tool to find text in plain text files.' +
    sLineBreak + 'Built by Ben a.k.a DreamVB',
    mtInformation, [mbOK], 0);
end;

procedure Tfrmmain.cmdAddFolderClick(Sender: TObject);
begin
  AddFolder;
end;

procedure Tfrmmain.cmdClearListClick(Sender: TObject);
begin
  if lstFiles.Count <> 0 then
  begin
    if MessageDlg(Text, 'Are you sure you want to clear all the items.',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      lstFiles.Clear;
      lblFindChange(Sender);
    end;
  end;
end;

procedure Tfrmmain.cmdCopyClick(Sender: TObject);
begin
  if txtlines.SelLength = 0 then
  begin
    //Select all the text
    txtlines.SelectAll;
    txtlines.SetFocus;
  end;
  txtLines.CopyToClipboard;
end;

procedure Tfrmmain.cmdExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Tfrmmain.cmdOpenListClick(Sender: TObject);
begin
  OpenList;
end;

procedure Tfrmmain.cmdRemoveFileClick(Sender: TObject);
var
  X: integer;
begin
  if lstFiles.SelCount > 0 then
  begin
    if MessageDlg(Text, 'Are you sure you want to remove the selected items.',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      for X := lstFiles.Count - 1 downto 0 do
      begin
        if lstFiles.Selected[X] then
        begin
          LstFiles.Items.Delete(X);
        end;
      end;
    end;
    if lstFiles.Count <> 0 then
    begin
      lstFiles.ItemIndex := 0;
      lstFiles.Selected[0] := True;
    end;
    lblFindChange(Sender);
  end;
end;

procedure Tfrmmain.cmdSaveLineClick(Sender: TObject);
var
  sd: TSaveDialog;
begin
  sd := TSaveDialog.Create(self);
  sd.Title := 'Save Text';
  sd.Filter := def_ext;
  sd.DefaultExt := 'txt';

  if sd.Execute then
  begin
    if FileExists(sd.FileName) then
    begin
      if MessageDlg(Text, 'The filename:' + sLineBreak + sLineBreak +
        sd.FileName + ' Already exists.' + sLineBreak + sLineBreak +
        'Are you sure you want to continue.', mtConfirmation, [mbYes, mbNo], 0) =
        mrYes then
      begin
        //Save lines
        txtLines.Lines.SaveToFile(sd.FileName);
      end;
    end
    else
    begin
      //Save lines
      txtLines.Lines.SaveToFile(sd.FileName);
    end;
  end;
  FreeAndNil(sd);

end;

procedure Tfrmmain.cmdSaveListClick(Sender: TObject);
begin
  SaveList;
end;

procedure Tfrmmain.cmdSearchClick(Sender: TObject);
var
  id: integer;
  lzFile: string;
begin
  //Get list index
  id := lstFiles.ItemIndex;
  //Get selected item index item
  lzFile := lstFiles.Items[id];
  //Load found lines into memo
  FindInFile(lzFile, lblFind.Text);
end;

procedure Tfrmmain.lblFindChange(Sender: TObject);
var
  id: integer;
begin
  //Get list index
  id := lstFiles.ItemIndex;

  cmdSearch.Enabled := (Length(lblFind.Text) <> 0) and (id <> -1) and
    (lstFiles.Selected[id]);
end;

procedure Tfrmmain.lblFindFileChange(Sender: TObject);
begin
  if lstFiles.Count > 0 then
  begin
    FindFileInList(lstFiles, lblFindFile.Text);
  end;
end;

procedure Tfrmmain.lblFindKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if cmdSearch.Enabled then
    begin
      cmdSearchClick(Sender);
    end;
  end;
end;

procedure Tfrmmain.lstFilesClick(Sender: TObject);
begin
  lblFindChange(Sender);
end;

procedure Tfrmmain.lstFilesDrawItem(Control: TWinControl; Index: integer;
  ARect: TRect; State: TOwnerDrawState);
var
  YPos: integer;
begin
  if odSelected in State then
  begin
    lstFiles.Canvas.Brush.Color := $00A87189;
  end;
  //Draw the icons in the listbox
  lstFiles.Canvas.FillRect(ARect);
  //Draw the icon on the listbox from the image list.
  ImgIcons.Draw(lstFiles.Canvas, ARect.Left + 4, ARect.Top + 4, 0);
  //Align text
  YPos := (ARect.Bottom - ARect.Top - lstFiles.Canvas.TextHeight(Text)) div 2;
  //Write the list item text
  lstFiles.Canvas.TextOut(ARect.left + ImgIcons.Width + 8, ARect.Top + YPos,
    lstFiles.Items.Strings[index]);
end;

procedure Tfrmmain.lstFilesMeasureItem(Control: TWinControl; Index: integer;
  var AHeight: integer);
begin
  AHeight := ImgIcons.Height + 8;
end;

end.
