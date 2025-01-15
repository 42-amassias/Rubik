TARGET		:=	target/rubik-1.0-SNAPSHOT.jar
JAVA_SRC	:=	$(shell find src/main/java -type f -name \*.java)

all: $(TARGET)

$(TARGET): $(JAVA_SRC)
	@mvn package

run: $(TARGET)
	@java -jar $(TARGET)
