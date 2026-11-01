Extension { #name : 'MicRichTextComposer' }

{ #category : '*Golap-Notepad' }
MicRichTextComposer >> visitGolapClip: aMicGolapScriptBlock [

	| clipId |
	clipId := aMicGolapScriptBlock body asString trim.
	GolapProject current note
		clipAt: clipId
		ifPresent: [ :clip |
				| buttonText |
				buttonText := ' 開く ' asText
					              addAttribute: (TextBackgroundColor color: (Color gray: 0.8));
					              addAttribute: (MicRichTextDoIt new
							               actOnClickBlock: [ clip open ];
							               yourself).
				canvas
					<< clip image asText;
					newLine;
					<< buttonText;
					newLine;
					newLine ]
		ifAbsent: [
				canvas
					<< ('クリップ' , clipId , 'が見つかりません') asText;
					newLine ]
]
