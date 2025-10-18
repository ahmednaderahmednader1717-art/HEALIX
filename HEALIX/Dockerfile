# استخدم صورة الـ SDK لبناء المشروع
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# انسخ كل الملفات للمسار داخل الكونتينر
COPY . .

# استرجع الـ dependencies
RUN dotnet restore "./HEALIX.csproj"

# ابني المشروع في وضع الإصدار
RUN dotnet publish "./HEALIX.csproj" -c Release -o /publish

# استخدم runtime خفيف للتشغيل
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=build /publish .

# افتح البورت بتاع الـ API (نفس اللي في launchSettings.json)
EXPOSE 5054

# شغّل التطبيق
ENTRYPOINT ["dotnet", "HEALIX.dll"]
