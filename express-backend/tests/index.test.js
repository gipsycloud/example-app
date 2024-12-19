const request = require("supertest");
const { app } = require("../index");

describe("GET /api/v1/hello", () => {
  test('should return a JSON response with the message "Hello!"', async () => {
    const response = await request(app).get("/api/v1/hello").expect(200);

    expect(response.body.message).toBe("Hello!");
  });

  test('should not return a JSON response with the message "hi"', async () => {
    const response = await request(app).get("/api/v1/hello").expect(200);

    expect(response.body.message).not.toBe("hi");
  });
});

describe("GET /api/v1/invalid", () => {
  test("should return an error", async () => {
    const response = await request(app).get("/api/v1/invalid").expect(404);

    expect(response.body.error).toBe("Route not found");
  });
});
