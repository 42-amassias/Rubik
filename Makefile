TARGET		:=	target/rubik-1.0-SNAPSHOT.jar
JAVA_SRC	:=	$(shell find src/main/java -type f -name \*.java)
POM			:=	pom.xml

all: $(TARGET)

$(TARGET): $(POM) $(JAVA_SRC)
	@mvn package

run: $(TARGET)
	@java -jar $(TARGET)
