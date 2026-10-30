Class {
	#name : 'GolapMicTextStyler',
	#superclass : 'MicTextStyler',
	#category : 'Golap-Notepad-Microdown',
	#package : 'Golap-Notepad',
	#tag : 'Microdown'
}

{ #category : 'private' }
GolapMicTextStyler >> computeHeaderFonts [

	headerFonts := Array new: self headerFontSizes size.
	1 to: headerFonts size do: [ :index |
			headerFonts
				at: index
				put:
				(TextFontReference toFont: (LogicalFont familyName: Golap defaultFont familyName pointSize: (self headerFontSizes at: index))) ]
]
