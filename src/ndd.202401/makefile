run:
	dotnet run --launch-profile https
publish:
	dotnet publish --self-contained -r linux-x64 --property:PublishDir=../out /p:Configuration=Release,PublishSingleFile=true,IncludeNativeLibrariesForSelfExtract=true
