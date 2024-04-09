
import unittest
import json
from hellopy import lambda_handler  

class TestLambdaHandler(unittest.TestCase):
    def test_lambda_handler(self):
        event = {}
        context = {}
        response = lambda_handler(event, context)
        self.assertEqual(response['statusCode'], 200)
        self.assertEqual(json.loads(response['body']), 'Hello from SAM!')

if __name__ == '__main__':
    unittest.main()