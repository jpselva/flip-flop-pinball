import pygame
import paho.mqtt.client as mqtt


MQTT_INFO = {
    "url": "broker.hivemq.com",
    "port": 1883,
    "main_topic": "911030-jp",
    "sub_topics": {
        "state": "state"
    }
}


class CustomEvents:
    STARTED = pygame.event.custom_type()
    SCORED = pygame.event.custom_type()
    MATCH_ENDED = pygame.event.custom_type()
    RESTARTED = pygame.event.custom_type()
    GAME_ENDED = pygame.event.custom_type()


class GameEventGenerator:
    def __init__(self):
        self.url = MQTT_INFO["url"]
        self.port = MQTT_INFO["port"]
        self.main_topic = MQTT_INFO["main_topic"]
        self.sub_topics = MQTT_INFO["sub_topics"]

        self.client = mqtt.Client()

        def on_connect(*args):
            self.on_connect(*args)

        def on_message(*args):
            self.on_message(*args)

        self.client.on_connect = on_connect
        self.client.on_message = on_message

    def on_connect(self, client, userdata, flags, rc):
        print("LOG: GameEventGenerator -- connected")
        for sub_topic in dict.values(self.sub_topics):
            client.subscribe(self.main_topic + '/' + sub_topic)

    def on_message(self, client, userdata, msg):
        print("LOG: GameEventGenerator -- got message [" +
              msg.topic+"] "+str(msg.payload))
        subtopic = msg.topic.split('/', maxsplit=1)[0]
        self.post_event(subtopic, msg.payload.decode("utf-8"))

    def post_event(self, subtopic, content):
        match [content[0], content[1:]]:
            case ["I", _]:
                print("game started")

            case ["R", _]:
                print("game restarted")

            case ["B", _]:
                print("match ended")

            case ["F", _]:
                print("game ended")

            case["P", points]:
                print("scored " + points)

    def start(self):
        self.client.connect(self.url, self.port, 60)
        self.client.loop_start()

    def stop(self):
        self.client.loop_stop()
        self.client.disconnect()


class App:
    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((1280, 720))
        self.clock = pygame.time.Clock()
        self.running = True
        self.game_event_gen = GameEventGenerator()

    def initialize(self):
        self.game_event_gen.start()

    def run(self):
        while self.running:
            for event in pygame.event.get():
                self.handle_event(event)

            self.screen.fill("purple")
            pygame.display.flip()
            self.clock.tick(60)

    def handle_event(self, event):
        if event.type == pygame.QUIT:
            self.running = False

    def cleanup(self):
        self.game_event_gen.stop()
        pygame.quit()


if __name__ == "__main__":
    app = App()
    app.initialize()
    app.run()
    app.cleanup()
