TARGET		:=	target/rubik-1.0-SNAPSHOT.jar
EXE			:=	rubik
JAVA_SRC	:=	$(shell find src/main/java -type f -name \*.java)
POM			:=	pom.xml

all: $(EXE)

$(EXE): $(TARGET)
	@echo '#!java -jar' > $(EXE)
	@cat $(TARGET) >> $(EXE)
	@chmod +x $(EXE)

$(TARGET): $(POM) $(JAVA_SRC)
	@mvn package

fclean:
	@rm -rf target $(EXE)
