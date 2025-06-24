from locust import HttpUser, task

class User(HttpUser):
    @task
    def hello(self):
        self.client.get("/")
    
    @task
    def status(self):
        self.client.get("/status")